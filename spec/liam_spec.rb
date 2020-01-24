# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Liam do
  it 'test that it has a version_number' do
    expect(Liam::VERSION).to_not be_nil
  end
end
