require 'rest_client'
require 'nokogiri'
require 'json'
require 'iconv'
require 'uri'
require 'capybara'
require 'selenium-webdriver'

class Spider

  include Capybara::DSL

  def initialize
    Capybara.default_driver = :selenium
    @category_page_front_url = "http://course-query.acad.ncku.edu.tw/qry/"
    @category_pages = []
    @courses = []
    @course_count = 0
  end

  def prepare_data
    visit "http://course-query.acad.ncku.edu.tw/qry/index.php"
    @home_page = Nokogiri::HTML(page.html)
    @home_page.css('.dept a').each_with_index do |category_page, index|
      @category_pages << category_page['href']
    end
  end

  def get_category_page_data
    puts "You got #{@category_pages.length} categories in NCKU course"

    @category_pages.each do |category|
      puts "visiting #{@category_page_front_url + category.to_s}"
      visit @category_page_front_url + category.to_s
      courses = Nokogiri::HTML(page.html)
      puts "you got #{courses.css('.course_y1').length} courses in this category"
      revised_courses = courses.css('.course_y1')
      revised_courses.each do |course|
        department = course.css('td')[0].text
        department_code = course.css('td')[1].text
        serial_number = course.css('td')[2].text
        course_code = course.css('td')[3].text
        placement_code = course.css('td')[4].text
        class_category = course.css('td')[5].text
        grade = course.css('td')[6].text
        _category = course.css('td')[7].text
        group_category = course.css('td')[8].text
        english_teaching = course.css('td')[9].text
        course_name = course.css('td')[10].text
        # 課程詳細資料連結
        course_detail_information = course.css('td')[10].css('a').first['href']
        obligatory_or_elective = course.css('td')[11].text
        credit = course.css('td')[12].text
        teacher_name = course.css('td')[13].text
        participated_headcount = course.css('td')[14].text
        remaining = course.css('td')[15].text
        time = course.css('td')[16].text
        classroom = course.css('td')[17].text
        remark = course.css('td')[18].text
        restrictions = course.css('td')[19].text
        export_participating = course.css('td')[20].text
        property_code = course.css('td')[21].text
        cross_cutting_learning = course.css('td')[22].text
        moocs = course.css('td')[23].text

        @courses << {
          department: department,
          department_code: department_code,
          serial_number: serial_number,
          course_code: course_code,
          placement_code: placement_code,
          class_category: class_category,
          grade: grade,
          category: _category,
          group_category: group_category,
          english_teaching: english_teaching,
          course_name: course_name,
          course_detail_information: course_detail_information,
          obligatory_or_elective: obligatory_or_elective,
          credit: credit,
          teacher_name: teacher_name,
          participated_headcount: participated_headcount,
          remaining: remaining,
          time: time,
          classroom: classroom,
          remark: remark,
          restrictions: restrictions,
          export_participating: export_participating,
          property_code: property_code,
          cross_cutting_learning: cross_cutting_learning,
          moocs: moocs
        }
        @course_count += 1
      end
    end
    puts "NCKU has #{@course_count} courses"
  end

  def save
    File.open('NCKU_Course_data.json', 'w') {|f| f.write(JSON.pretty_generate(@courses))}
  end

end





s = Spider.new
s.prepare_data
s.get_category_page_data
s.save