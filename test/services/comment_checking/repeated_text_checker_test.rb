require 'test_helper'

class RepeatedTextCheckerTest < ActiveSupport::TestCase
  test 'when it is a repost by a new user of one of their previous comments' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content')
    comment.poster.update!(created_at: 1.day.ago)
    second_comment = comment.dup
    second_comment.save!

    checker = CommentChecking::RepeatedTextChecker.new(second_comment, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot')
    assert_not checker.skip?
    assert checker.check.spam?
  end

  test 'when it is a repost by an existing user of one of their previous comments' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content')
    comment.poster.update!(created_at: 1.month.ago)
    second_comment = comment.dup
    second_comment.save!

    assert CommentChecking::RepeatedTextChecker.new(second_comment, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot').skip?
  end
end
