class Admin::MachineLearning::SettingsComponent < ApplicationComponent
  private

    def settings
      @settings ||= Setting.by_group(:machine_learning)
    end

    def filenames
      ::MachineLearning.data_intermediate_files
    end

    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
