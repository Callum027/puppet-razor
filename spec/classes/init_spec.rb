require 'spec_helper'
describe 'razor' do

  context 'with defaults for all parameters' do
    it { should contain_class('razor') }
  end
end
