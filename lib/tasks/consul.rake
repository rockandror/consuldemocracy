namespace :consul do
  desc "Runs tasks needed to upgrade to the latest version"
  task execute_release_tasks: ["settings:rename_setting_keys",
                               "settings:add_new_settings",
                               "execute_release_1.2.0_tasks"]

  desc "Runs tasks needed to upgrade from 1.1.0 to 1.2.0"
  task "execute_release_1.2.0_tasks": [
    "budgets:update_drafting_budgets"
  ]
end
