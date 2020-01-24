# frozen_string_literal: true

namespace :liam do
  namespace :consumer do
    desc 'Launch Liam consumer'
    task start: :environment do
      Liam::Consumer.message
    end
  end
end
