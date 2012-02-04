class When < ActiveRecord::Base
  validate :year_span
  
  private
  def year_span
    unless year.to_i.between?(1950, 2050)
      errors[:year] << "must be between 1950 and 2050"
    end
  end
end
