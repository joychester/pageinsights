require 'sinatra'
require 'haml'
require 'fileutils'
require 'cgi'

Root_Path = Dir.pwd

MAX_TEST_RND = "7"

configure do
    set :bind, '0.0.0.0'
    set :root, File.expand_path("#{File.dirname(__FILE__)}")
    set :views, Root_Path + '/views'
    set :port, 8081
    enable :sessions
    disable :logging
end

#define MIME type of static resources
before /.*\.css/ do
    content_type 'text/css'
end

before /.*\.js/ do
    content_type 'application/javascript'
end


get '/' do
    #empty session data
    #Rack::Session::Abstract::SessionHash
    if !session.empty?
        session.clear
    end

    redirect '/results'
end

get '/speedtest-result/*' do
    puts @page_view =  params['splat'].first
    File.read "#{Root_Path}/speedtest-result/#{@page_view}"
end

get '/results' do
    #empty session data
    if !session.empty?
        session.clear
    end

    Dir.chdir("#{Root_Path}/sitespeed-result")
    env_arr = Dir.glob("*")

    @env = {}
    env_arr.each { |item|
        link = '/env?site=' + item
        @env[item] = link
    }
    haml :sites

end

#matches '/env?site=aaa' request
get '/env' do
    #empty session data
    if !session.empty?
        session.clear
    end

    #redirect '/results/sitespeedio/2015-03-10-06-43-38/index.html'
    Dir.chdir("#{Root_Path}/sitespeed-result/#{params[:site]}")
    pages_arr = Dir.glob("*")

    @pages = {}
    pages_arr.each { |item|
        link = "/pages?site=#{params[:site]}&pn=#{item}"
        @pages[item] = link
    }
    #p "pages :" + @pages.to_s
    haml :pages
end

#matches '/pages?site=a&pn=aaa' request
get '/pages' do
    Dir.chdir("#{Root_Path}/sitespeed-result/#{params[:site]}/#{params[:pn]}")
    samples_arr = Dir.glob("*").sort! {|x,y| y <=> x}

    @samples = {}
    samples_arr.each { |item|
        link = "/details?site=#{params[:site]}&pn=#{params[:pn]}&ts=" + item
        @samples[item] = link
    }
    #p "samples :" + @samples.to_s
    haml :samples
end

#matches '/details?site=a&pn=aaa&ts=2015-03-04' request
get '/details' do

    Dir.chdir("#{Root_Path}/sitespeed-result/#{params[:site]}/#{params[:pn]}/#{params[:ts]}")
    details_arr = Dir.glob("*")

    @details = {}
    details_arr.each { |item|
        if item.eql? "index.html"
            link = "/index?site=#{params[:site]}&pn=#{params[:pn]}&ts=#{params[:ts]}"
            @details[item] = link
            break;
        end
    }
    #check if there is index.html or not
    if @details.empty?
        @details = {"index.html" => "404.html"}
    end

    session[:page_site] = params[:site]
    session[:page_name] = params[:pn]
    session[:page_ts] = params[:ts]
    File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/index.html"
end

get '/detailed.html' do
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/detailed.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end

end

get '/pages.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/pages.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

#https://sinatra-sitespeed-joychester.c9.io/pages/www.domainName.co.uk/index.html
#https://sinatra-sitespeed-joychester.c9.io/pages/www.domainName.co.uk/0.html
get '/pages/*/:round.html' do |t, r|
   p 'access to detail pages view'

   begin
       File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/pages/#{t}/#{r}.html"
   rescue
       send_file "#{Root_Path}/public/img/404.jpg"
   end
end

#https://sinatra-sitespeed-joychester.c9.io/pages/www.domainName.co.uk/data/screenshots/0.png
get '/pages/*/data/*.*' do |t, path, ext|
   p 'access to data repo'
   begin
       File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/pages/#{t}/data/#{path}.#{ext}"
   rescue
       send_file "#{Root_Path}/public/img/404.jpg"
   end
end


get '/assets.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/assets.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/toplist.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/toplist.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/domains.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/domains.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end


get '/help.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/help.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/errors.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/errors.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/rules.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/errors.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/index.html' do
    
    begin
        File.read "#{Root_Path}/sitespeed-result/#{session[:page_site]}/#{session[:page_name]}/#{session[:page_ts]}/index.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/compare' do
    puts "compare route"
    begin
        puts "load compare html"
        File.read "#{Root_Path}/compare/compare.html"
    rescue
        send_file "#{Root_Path}/public/img/404.jpg"
    end
end

get '/speedtest' do
    # matches "GET /speedtest?option1=a&option2=b"
    # get query parameters as hash value
    puts "page test started"
  begin
    #/speedtest?r=3&b=chrome&u=%3Chttps%3A%2F%2Fwww.domainName.com%2F%3E&user=W44A9TSG6&channel=C8PTN9Z24
    puts params.to_s

    @cmds = 'docker run --shm-size=1g ' + ' --rm -v "$(pwd)":/sitespeed.io sitespeedio/sitespeed.io:11.9.3'

    @url = params["u"]
    @browser = params["b"].nil? ? "chrome" : params["b"]
    @rounds = params["r"].nil? ? "3" : (params["r"].to_i > MAX_TEST_RND.to_i ? MAX_TEST_RND : params["r"])
    @env  = params["e"].nil? ? "env" : params["e"]
    @page = params["t"].nil? ? "pages" : params["t"]
    @mobile = (params["m"].nil? || params["m"].downcase != "mobile") ? "false" : "true"
    @user_agent = params["ua"].nil? ? "" : ("--userAgent " + + %Q(#{params["ua"].strip}).insert(0, '"').insert(-1, '"'))
    @header = params["h"].nil? ? "" : ("-r " + params["h"].strip)
    @cookie = params["ck"].nil? ? "" : ("--cookie " + params["ck"].strip)
    @whitelist = params["wl"].nil? ? "" : params["wl"].strip
    @domains = ""
    if !@whitelist.empty?
      @whitelist.split(",").each { |dn|
        #domain = dn.split("|")[1].chop
        dn.sub!(/<.*?\|/, '').chop!
        @domains << "--chrome.blockDomainsExcept #{dn} "
      }
    end

    @multi_pages = params["mu"].nil? ? "" : ("--multi " + params["mu"].strip)
    @multi_script = params["ms"].nil? ? "" : ("--multi " + "speedtest-result/#{@slack_user}/test_scripts/" + params["ms"].strip)
    @pre_script = params["s"].nil? ? "" : ("--preScript " + "speedtest-result/#{@slack_user}/test_scripts/" + params["s"].strip)
    @page_complete_check = params["pcc"].nil? ? "" : ("--browsertime.pageCompleteCheck " + %Q(#{params["pcc"].strip}).insert(0, '"').insert(-1, '"'))
    @result_path = "speedtest-result/#{@env}/#{@page}/" + Time.now.to_i.to_s

    if !@url.nil? || !@multi_pages.nil? || !@multi_script.nil?

        if !@url.nil?
          @url.gsub!(/&amp;/ , '&')
          @url = @url.scan(/<([^>]*)>/).first.last
          @url.strip!
          @url.insert(0, '"').insert(-1, '"')
          @cmds << " " + @url
        end
        @cmds << " " + "-b " + @browser.strip
        @cmds << " " + "-n " + @rounds.strip
        @cmds << " " + "--outputFolder " + @result_path.strip
        @cmds << " " + "--mobile " + @mobile.strip
        @cmds << " " + @header
        @cmds << " " + @user_agent
        @cmds << " " + @cookie
        @cmds << " " + @domains
        @cmds << " " + @multi_pages.gsub(/[<>]/, '')
        @cmds << " " + @multi_script
        @cmds << " " + @pre_script
        @cmds << " " + CGI::unescapeHTML(@page_complete_check)
        @cmds << " " + "--speedIndex --video --gzipHAR true --utc true"

        puts @cmds
    else
        #return error msg and send to slack channel
        raise "Test aborted, due to missing the test URL, please retry"
    end


    puts @cmds

    # start docker process to run the sitespeed Io tests
    #system("sudo docker login --username demo --password 1234")

    @t_status = false
    @t_status = system(@cmds)

    if @t_status
        puts "it works..."
    else
        puts "it sucks..."
    end

  rescue Exception => e
  end

end
