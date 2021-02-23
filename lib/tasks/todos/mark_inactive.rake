namespace :todos do
  desc "Mark old Todos inactive"
  task :mark_inactive do
    MarkTodosInactiveJob.perform_now
  end
end
