class Performance < ActiveRecord::Base
  # возвращает все записи в формате CSV
  # >> puts Performance.to_csv(:day => 1.day.ago.to_date)
  # ...
  # >> puts Performance.to_csv(:day => Time.now.to_date)
  # ...
  # >> puts Performance.to_csv
  # ... общая статистика за весь период ...
  def self.to_csv(options = {})
    ["controller,action,calls,realtime,stime,utime,cstime,cutime",
      (options[:day] ? \
        Performance.find(:all, :conditions => ['day = ?', options[:day]], :order => options[:order]) : \
        Performance.find_by_sql("SELECT controller, action, sum(calls) as calls, sum(realtime) as realtime, sum(stime) as stime, sum(utime) as utime, sum(cstime) as cstime, sum(cutime) as cutime FROM #{table_name} GROUP BY controller, action #{" ORDER BY #{options[:order]}" if options[:order]}")
      ).collect { |p| p.to_csv }
    ].join("\n")
  end

  # возвращает текущую запись в формате CSV
  def to_csv
    [self.controller, self.action, self.calls, self.realtime.to_csv, self.stime.to_csv, self.utime.to_csv, self.cstime.to_csv, self.cutime.to_csv].join(',')
  end
end
