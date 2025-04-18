require 'test_helper'

class DeletedRepeatedLinkCheckerTest < ActiveSupport::TestCase
  test 'when it is a link repost by a new user of a recently deleted comments' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content with a link: https://example.com', created_at: 1.day.ago)

    comment_to_check = comment.dup
    comment_to_check.text = 'some other content with the same link: https://example.com'
    comment_to_check.created_at = Time.zone.now
    comment_to_check.poster = users(:one)
    comment_to_check.poster.update!(created_at: 1.day.ago)
    comment_to_check.save!

    comment.update(deleted_at: Time.zone.now)
    second_comment = comment.dup
    second_comment.created_at = 1.day.ago
    second_comment.save!

    assert CommentChecking::DeletedRepeatedLinkChecker.check(comment_to_check, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot').spam?
  end

  test 'when it is a link repost by an existing user of a recently deleted comment' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content with a link: https://example.com', created_at: 1.day.ago)

    comment_to_check = comment.dup
    comment_to_check.text = 'some other content with the same link: https://example.com'
    comment_to_check.created_at = Time.zone.now
    comment_to_check.poster = users(:one)
    comment_to_check.poster.update!(created_at: 1.month.ago)
    comment_to_check.save!

    comment.update(deleted_at: Time.zone.now)
    second_comment = comment.dup
    second_comment.created_at = 1.day.ago
    second_comment.save!

    assert_not CommentChecking::DeletedRepeatedLinkChecker.check(comment_to_check, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot').spam?
  end

  test 'when it is a link repost by a new user of a non-deleted comment' do
    comment = comments(:script_comment)
    comment.update!(text: 'totally unique content with a link: https://example.com', created_at: 1.day.ago)
    second_comment = comment.dup
    second_comment.created_at = 1.day.ago
    second_comment.save!

    comment_to_check = comment.dup
    comment_to_check.text = 'some other content with the same link: https://example.com'
    comment_to_check.created_at = Time.zone.now
    comment_to_check.poster = users(:one)
    comment_to_check.poster.update!(created_at: 1.day.ago)
    comment_to_check.save!

    assert_not CommentChecking::DeletedRepeatedLinkChecker.check(comment_to_check, ip: '127.0.0.1', referrer: nil, user_agent: 'Bot').spam?
  end
end
