class CommentCheckingService
  STRATEGIES = [
    CommentChecking::AkismetChecker,
    CommentChecking::DefendiumChecker,
    CommentChecking::CustomChecker,
    CommentChecking::LinkCountChecker,
    CommentChecking::RepeatedTextChecker,
    CommentChecking::DeletedRepeatedTextChecker,
    CommentChecking::DeletedRepeatedLinkChecker,
    CommentChecking::OnlyLinkChecker,
  ].freeze

  def self.check(comment, ip:, user_agent:, referrer:)
    return if comment.reports.any?

    results = STRATEGIES.map { |s| s.check(comment, ip:, user_agent:, referrer:) }

    spam_results = results.select(&:spam?)
    return if spam_results.empty?

    report = Report.create!(item: comment.reportable_item, auto_reporter: 'rainman', reason: Report::REASON_SPAM, private_explanation: spam_results.map(&:text).map { |t| "- #{t}" }.join("\n").truncate_bytes(65_535))

    if spam_results.count { |sr| !(sr.strategy == CommentChecking::DefendiumChecker) } >= 2 && strict_results?(comment)
      report.uphold!(moderator_notes: 'Blatant comment spam', ban_user: true, delete_comments: true, delete_scripts: true, automod: true)
    elsif report.item.is_a?(Discussion)
      report.item.update!(review_reason: Discussion::REVIEW_REASON_RAINMAN)
    end
  end

  def self.strict_results?(comment)
    comment.poster.created_at >= 7.days.ago
  end
end
