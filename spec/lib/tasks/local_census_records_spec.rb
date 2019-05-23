require "rails_helper"

describe LocalCensusRecords do

  context "Remove dups" do

    let :run_rake_task do
      Rake::Task["local_census_records:remove_dups"].reenable
      Rake.application.invoke_task "local_census_records:remove_dups"
    end

    it "Removes exactly duplicated records" do
      attributes = { document_type: "DNI", document_number: "#DOC_NUMBER",
                     date_of_birth: 20.years.ago, postal_code: "07007"}
      2.times.each do
        local_census_record = build(:local_census_record, **attributes)
        local_census_record.save(validate: false)
      end
      expect(LocalCensusRecord.count).to eq(2)

      run_rake_task

      expect(LocalCensusRecord.count).to eq(1)
    end

    it "Removes also case insensitive duplicated records " do
      attributes = { document_type: "DNI", document_number: "#DOC_NUMBER",
                     date_of_birth: 20.years.ago, postal_code: "07007"}
      local_census_record = build(:local_census_record, **attributes)
      local_census_record.save(validate: false)
      dirty_attributes = { document_type: "dni", document_number: "#doc_number",
                     date_of_birth: 20.years.ago, postal_code: "07007"}
      local_census_record = build(:local_census_record, **dirty_attributes)
      local_census_record.save(validate: false)
      expect(LocalCensusRecord.count).to eq(2)

      run_rake_task

      expect(LocalCensusRecord.count).to eq(1)
    end
  end
end
