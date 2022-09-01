class Admin::Poll::ResultsComponent < ApplicationComponent
  attr_reader :poll

  def initialize(poll:)
    @poll = poll
  end
end
