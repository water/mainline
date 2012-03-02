class When < ActiveRecord::Base
  validate :year_span, :study_period_span, :uniqueness_of_time_span
  validates_presence_of :year, :study_period
  
  private
  def year_span
    unless year.to_i.between?(1950, 2050)
      errors[:year] << "must be between 1950 and 2050"
    end
  end
  
  def study_period_span
    if study_period.to_i <= 0
      errors[:study_period] << "must be greater than 0"
    end    
  end
  
  def uniqueness_of_time_span
    if record = When.where(year: year, study_period: study_period).first
      errors[:base] << "Combination of year and study period should be unique. Existing record with id: #{record.id} already has same combo."
    end
  end
end
