#!/usr/bin/env ruby
# encoding: utf-8

require 'open-uri'
require 'optparse'

weather_symbols = {
  clear: '☀',
  cloudy: '☁',
  rainy: '☂',
  snowy: '❄', #'❅''☃'
  windy: '☴',
  lightning: '⚡', #☇☈ϟ⚡
  sunny: '☼',  #☉
  clearnight: '☾', #☽
}

weather_codes = {
  '0' => ['tornado', :windy, 3],
  '1' => ['tropical storm', :windy, 3],
  '2' => ['hurricane', :windy, 3],
  '3' => ['severe thunderstorms', :lightning, 3],
  '4' => ['thunderstorms', :lightning, 2],
  '5' => ['mixed rain and snow', [:snowy, :rainy]],
  '6' => ['mixed rain and sleet', [:snowy, :rainy]],
  '7' => ['mixed snow and sleet', [:snowy, :rainy]],
  '8' => ['freezing drizzle', [:snowy, :rainy]],
  '9' => ['drizzle', :rain, 1],
  '10' => ['freezing rain', [:snowy, :rainy]],
  '11' => ['showers', :rain, 1],
  '12' => ['showers',:rain, 1],
  '13' => ['snow flurries', :snowy, 2],
  '14' => ['light snowshowers', :snowy, 1],
  '15' => ['blowing snow', [:snowy, :windy]],
  '16' => ['snow', :snowy, 1],
  '17' => ['hail', [:snowy, :rainy], 3],
  '18' => ['sleet', [:snowy, :rainy], 1],
  '19' => ['dust', ],
  '20' => ['foggy', :cloudy],
  '21' => ['haze', :cloudy],
  '22' => ['smoky', :cloudy],
  '23' => ['blustery', :windy, 3],
  '24' => ['windy', :windy, 2],
  '25' => ['cold', ],
  '26' => ['cloudy', :cloudy, 3],
  '27' => ['mostly cloudy (night)', :cloudy, 2],
  '28' => ['mostly cloudy (day)', :cloudy, 2],
  '29' => ['partly cloudy (night)', :cloudy, 1],
  '30' => ['partly cloudy (day)', :cloudy, 1],
  '31' => ['clear (night)', :clearnight],
  '32' => ['sunny', :sunny],
  '33' => ['fair (night)'],
  '34' => ['fair (day)'],
  '35' => ['mixed rain and hail', [:snowy, :rainy]],
  '36' => ['hot', :sunny],
  '37' => ['isolated thunderstorms', :lightning, 1],
  '38' => ['scattered thunderstorms', :lightning, 1],
  '39' => ['scattered thunderstorms', :lightning, 1],
  '40' => ['scattered showers', :rainy, 1],
  '41' => ['heavy snow', :snowy, 3],
  '42' => ['scattered snow showers', :snowy, 1],
  '43' => ['heavy snow', :snowy, 3],
  '44' => ['partly cloudy', :cloudy, 1],
  '45' => ['thundershowers', :lightning, 2],
  '46' => ['snow showers', :snow, 1],
  '47' => ['isolated thundershowers', :lightning, 1],
  '3200' => ['not available', 'NA'],
}

places = {
  provo: '12794268',
  orem: '12794085',
  austin: '2357536',
}

def print_glyphs(weather_symbols)
  puts weather_symbols.values.join(" ")
end

opt = {
  dft_intensity: 1,
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <yahoo-weather-code|recognized-place>"
  op.separator "outputs: <TEMP (F)> <glyph> <intensity>"
  op.separator "no network, outputs to stdout: [No Connection]"
  op.separator "recognized: #{places.keys.join(', ')}"
  op.on("-t", "--text", "display condition as text instead of glyph") {|v| opt[:text] = true }
  op.on("-i", "--intensity <#{opt[:dft_intensity]}>", Integer, "intensity if none given") {|v| opt[:dft_intensity] = v.to_i }
  op.on("-g", "--print-glyphs", "prints all glyphs on 1 line and exits") { print_glyphs(weather_symbols) ; exit }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end


# returns [condition string, intensity]
def code_info_to_glyph(code, weather_codes, weather_symbols, dft_intensity, text=true)
  (name, glyph_key, intensity) = weather_codes[code]
  glyph_keys = glyph_key.is_a?(Array) ? glyph_key : [glyph_key]
  glyphs = glyph_keys.map {|key| weather_symbols[key] }
  condition_string = text ? name.gsub(' ','') : glyphs.join
  [condition_string, intensity || dft_intensity]
end

arg = ARGV.shift.to_sym

yahoo_w_code = places.key?(arg) ? places[arg] : arg

uri = "http://weather.yahooapis.com/forecastrss?w=#{yahoo_w_code}&u=f"

response = open(uri) {|f| f.read }
#response = DATA.read

unless response
  puts "[No Connection]"
  exit
end

tags_string = response[/<yweather:condition(.*?)\/>/,1].strip
conditions = Hash[tags_string.scan(/(\w+)="([^"]+)"/).map {|k,v| [k.to_sym, v] }]

(glyphs, intensity) = code_info_to_glyph(conditions[:code], weather_codes, weather_symbols, opt[:dft_intensity], opt[:text])
puts [conditions[:temp], glyphs, intensity].join(" ")



__END__
<title>Yahoo! Weather - Provo, UT</title>
<link>http://us.rd.yahoo.com/dailynews/rss/weather/Provo__UT/*http://weather.yahoo.com/forecast/USUT0191_f.html</link>
<description>Yahoo! Weather for Provo, UT</description>
<language>en-us</language>
<lastBuildDate>Thu, 17 Jan 2013 6:57 pm MST</lastBuildDate>
<ttl>60</ttl>
<yweather:location city="Provo" region="UT"   country="United States"/>
<yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
<yweather:wind chill="12"   direction="0"   speed="0" />
<yweather:atmosphere humidity="91"  visibility="5"  pressure="30.53"  rising="0" />
<yweather:astronomy sunrise="7:45 am"   sunset="5:26 pm"/>
<image>
<title>Yahoo! Weather</title>
<width>142</width>
<height>18</height>
<link>http://weather.yahoo.com</link>
<url>http://l.yimg.com/a/i/brand/purplelogo//uh/us/news-wea.gif</url>
</image>
<item>
<title>Conditions for Provo, UT at 6:57 pm MST</title>
<geo:lat>40.34</geo:lat>
<geo:long>-111.58</geo:long>
<link>http://us.rd.yahoo.com/dailynews/rss/weather/Provo__UT/*http://weather.yahoo.com/forecast/USUT0191_f.html</link>
<pubDate>Thu, 17 Jan 2013 6:57 pm MST</pubDate>
<yweather:condition  text="Clear"  code="31"  temp="12"  date="Thu, 17 Jan 2013 6:57 pm MST" />
<description><![CDATA[
<img src="http://l.yimg.com/a/i/us/we/52/31.gif"/><br />
<b>Current Conditions:</b><br />
Clear, 12 F<BR />
<BR /><b>Forecast:</b><BR />
Thu - Partly Cloudy. High: 25 Low: 8<br />
Fri - Partly Cloudy. High: 23 Low: 12<br />
<br />
<a href="http://us.rd.yahoo.com/dailynews/rss/weather/Provo__UT/*http://weather.yahoo.com/forecast/USUT0191_f.html">Full Forecast at Yahoo! Weather</a><BR/><BR/>
(provided by <a href="http://www.weather.com" >The Weather Channel</a>)<br/>
]]></description>
<yweather:forecast day="Thu" date="17 Jan 2013" low="8" high="25" text="Partly Cloudy" code="29" />
<yweather:forecast day="Fri" date="18 Jan 2013" low="12" high="23" text="Partly Cloudy" code="30" />
<guid isPermaLink="false">USUT0191_2013_01_18_7_00_MST</guid>
</item>
</channel>
</rss>
