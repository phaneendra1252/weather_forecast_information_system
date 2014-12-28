require 'spreadsheet'

class Array

  def to_xls(options = {}, &block)
    if options[:model_name].present?
      model_name = options[:model_name].constantize
    else
      return ''
    end
    xls_report = StringIO.new
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet
    header = []
    columns = []
    if options[:xls_data]
      header += options[:xls_data].values
      columns += options[:xls_data].keys
    end
    if header.present? && columns.present?
      sheet.row(0).concat(header.map(&:to_s))
    else
      return ''
    end
    self.each_with_index do |obj, index|
      if options[:xls_data].present?
        sheet.row(index + 1).replace(options[:xls_data].map { |k, v| obj.send(k) })
      end
    end
    book.write(xls_report)
    xls_report.string
  end

end