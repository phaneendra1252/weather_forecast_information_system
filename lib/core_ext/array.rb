require 'spreadsheet'

class Array

  def to_xls(options = {}, &block)
    #return '' if self.empty?

    model_name = nil

    if self.empty?
      model_name = options[:model_name].constantize
    else
      model_name = self.first.class
    end

    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    columns = []

    if options[:methods].present?
      columns = Array(options[:methods])
    end

    if options[:only].present?
      columns += Array(options[:only]).map(&:to_sym)
    elsif options[:except].present?
      columns += model_name.column_names.map(&:to_sym) - Array(options[:except]).map(&:to_sym)
    else
      columns += model_name.column_names.map(&:to_sym)
    end
    
    return '' if columns.empty?

    sheet.row(0).concat(columns.map(&:to_s).collect{|s| s.gsub("_", " ").titleize})

    self.each_with_index do |obj, index|
      if block
        sheet.row(index + 1).replace(columns.map { |column| block.call(column, obj.send(column)) })
      else
        sheet.row(index + 1).replace(columns.map { |column| obj.send(column) })
      end
    end

    book.write(xls_report)

    xls_report.string
  end

end
