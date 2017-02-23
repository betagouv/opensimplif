# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base
  def cache_dir
    '/tmp/opensimplif-cache'
  end
end