class Sams < Sample
  def self.all
    logs = [];
    find('/mnt/elabbook/data/sample_preparation/sams') do |f|
      if f.match(/.*log.xml$/)
        logs << Sams.new(f)
      end
    end
    return logs
  end
end
