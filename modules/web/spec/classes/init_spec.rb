require 'spec_helper'
describe 'web' do
  context 'with default values for all parameters' do
    it { should contain_class('web') }
  end
end
