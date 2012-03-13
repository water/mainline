class StudyPeriod < ActiveRecord::Base
  validate :year_span, :period_span, :uniqueness_of_time_span
  validates_presence_of :year, :period
  
  private
  def year_span
    unless year.to_i.between?(1950, 2050)
      errors[:year] << "must be between 1950 and 1950"
    end
  end
  
  def period_span
    if period.to_i <= 0
      errors[:period] << "must be greater than 0"
    end    
  end
  
  def uniqueness_of_time_span
    if record = StudyPeriod.where(year: year, period: period).first
      errors[:base] << %Q{
        Combination of year and study period should be unique. 
        Existing record with id: #{record.id} already has same combo.
      }
    end
  end
end
