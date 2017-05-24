# See:
# - https://robots.thoughtbot.com/implementing-multi-table-full-text-search-with-postgres
# - http://calebthompson.io/talks/search.html
class Search < ActiveRecord::Base
  # :nodoc:
  #
  # Englobs a search result (actually a collection of Search objects) so it acts
  # like a collection of regular Dossier objects, which can be decorated,
  # paginated, ...
  class Results
    include Enumerable

    def initialize(results)
      @results = results
    end

    def each
      @results.each do |search|
        yield search.dossier
      end
    end

    def decorate!
      @results.each do |search|
        search.dossier = search.dossier.decorate
      end
    end

    def method_missing(name, *args, &block)
      @results.__send__(name, *args, &block) || super
    end

    def respond_to_missing?(method_name, include_private = false)
      super
    end
  end

  attr_accessor :query
  attr_accessor :page

  belongs_to :dossier

  def results
    return Search.none unless @query.present?
    search_term = Search.connection.quote(to_tsquery)
    dossier_ids = Dossier.where(archived: false).where.not(state: 'draft').pluck(:id)

    q = Search
        .select('DISTINCT(searches.dossier_id)')
        .select("COALESCE(ts_rank(to_tsvector('french', searches.term::text), to_tsquery('french', #{search_term})), 0) AS rank")
        .joins(:dossier)
        .where(dossier_id: dossier_ids)
        .joins(dossier: :user)
        .where("to_tsvector('french', searches.term::text) @@ to_tsquery('french', #{search_term}) OR users.email ~ ?", @query)
        .order('rank DESC')
        .preload(:dossier)

    q = q.paginate(page: @page) if @page.present?

    Results.new(q)
  end

  # def self.refresh
  #  # TODO: could be executed concurrently
  #  # See https://github.com/thoughtbot/scenic#what-about-materialized-views
  #  Scenic.database.refresh_materialized_view(table_name, concurrently: false)
  # end

  private

  def to_tsquery
    @query.gsub(%r{['?\\:&|!]}, '') # drop disallowed characters
          .split(%r{\s+}) # split words
          .map { |x| "#{x}:*" } # enable prefix matching
          .join(' & ')
  end
end
