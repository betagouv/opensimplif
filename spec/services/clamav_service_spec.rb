require 'spec_helper'

describe ClamavService do
  describe '.safe_file?' do
    let(:path_file) { '/tmp/plop.txt' }

    subject { ClamavService.safe_file? path_file }

    before do
      allow(ClamAV::Client).to receive(:new).and_return(ClamAV::Client)
      allow(ClamAV::Client).to receive(:execute).and_return([ClamAV::SuccessResponse])
    end

    it 'change permission of file path' do
      allow(FileUtils).to receive(:chmod).with(0o666, path_file).and_return(true)

      subject
    end
  end
end
