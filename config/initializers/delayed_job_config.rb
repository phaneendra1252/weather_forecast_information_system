Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.max_attempts = 0

# Delayed::Worker.class_eval do

#   def handle_failed_job_with_notification(job, error)
#     handle_failed_job_without_notification(job, error)
#     ExceptionNotifier.notify_exception(error)
#   end

#   alias_method_chain :handle_failed_job, :notification

# end

# Chain delayed job's handle_failed_job method to do exception notification
Delayed::Worker.class_eval do
  def handle_failed_job_with_notification(job, error)
    handle_failed_job_without_notification(job, error)
    # only actually send mail in production
    if Rails.env.production?
      # rescue if ExceptionNotifier fails for some reason
      begin
        ExceptionNotifier.notify_exception(error)
      rescue Exception => e
        Rails.logger.error "ExceptionNotifier failed: #{e.class.name}: #{e.message}"
        e.backtrace.each do |f|
          Rails.logger.error "  #{f}"
        end
        Rails.logger.flush
      end
    end
  end
  alias_method_chain :handle_failed_job, :notification
end