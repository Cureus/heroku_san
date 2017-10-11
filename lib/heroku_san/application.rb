require 'platform-api'

module HerokuSan
  module Application
    def ensure_one_worker_running(at_least = 1)
      begin
        web_processes = heroku.formation(app, 'web')["quantity"]
      end until restart_processes(web_processes) >= at_least
    end

    def ensure_all_workers_running
      while true do
        processes = heroku.get_ps(app).body

        return if processes.all? { |p| p["state"] == "up" }

        restart_processes(processes)
      end
    end

    private

    def restart_processes(web_processes)
      up = 0
      web_processes.each do |process|
        case process["state"]
          when "up"
            up += 1
          when "crashed"
            heroku.dyno.restart_all(app)
        end
      end
      up
    end
  end
end
