require 'test_helper'

class DeletedRepeatedTextCheckerTest < ActiveSupport::TestCase
  test 'when it is a repost by a new user of a recently deleted comment' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content')
    second_comment = comment.dup
    second_comment.poster = users(:one)
    second_comment.poster.update!(created_at: 1.day.ago)
    second_comment.save!
    comment.update(deleted_at: Time.zone.now)

    checker = CommentChecking::DeletedRepeatedTextChecker.new(second_comment, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot')
    assert_not checker.skip?
    assert checker.check.spam?
  end

  test 'when it is a repost by an existing user of a recently deleted comment' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content')
    second_comment = comment.dup
    second_comment.poster = users(:one)
    second_comment.poster.update!(created_at: 1.month.ago)
    second_comment.save!
    comment.update(deleted_at: Time.zone.now)

    checker = CommentChecking::DeletedRepeatedTextChecker.new(second_comment, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot')
    assert checker.skip?
  end

  test 'when it is a repost by a new user of a non-deleted comment' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content')
    second_comment = comment.dup
    second_comment.poster = users(:one)
    second_comment.poster.update!(created_at: 1.day.ago)
    second_comment.save!

    checker = CommentChecking::DeletedRepeatedTextChecker.new(second_comment, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot')
    assert_not checker.skip?
    assert_not checker.check.spam?
  end
end
