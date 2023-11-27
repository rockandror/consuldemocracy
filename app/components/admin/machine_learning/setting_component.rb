class Admin::MachineLearning::SettingComponent < ApplicationComponent
  attr_reader :setting

  def initialize(setting)
    @setting = setting
  end

  private

    def kind
      setting.key.split(".").last
    end

    def ml_info
      @ml_info ||= MachineLearningInfo.for(kind)
    end

    def filenames
      ::MachineLearning.data_output_files[ml_info.kind.to_sym].sort
    end

    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
