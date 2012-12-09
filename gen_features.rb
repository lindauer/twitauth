#!/usr/bin/env ruby

# WARNING: Requires Ruby >= 1.9 because of hash key order must be preserved.

require 'ap'
require 'csv'

def main()
  want_header = true
  word_shapes = Hash['upper,lower,first_upper,camel_case,other_case'.split(',').collect {|v| [v, 0]}]
  word_lens = Hash[(1..20).collect{|i| ["words_len_#{i}", 0]}]
  num_chars = Hash[(0..9).to_a.collect {|v| [v, 0]}]
  alpha_chars = Hash[('a'..'z').to_a.collect {|v| [v, 0]}]
  punc_chars = Hash[".?!,;:()\"-'".split('').collect {|v| [v, 0]}]
  spec_chars = Hash["`~@#\$%^&*_+=[]{}\\|/<>".split('').collect {|v| [v, 0]}]

  func_words = Hash['a,able,aboard,about,above,absent,according,accordingly,across,after,against,ahead,albeit,all,along,alongside,although,am,amid,amidst,among,amongst,amount,an,and,another,anti,any,anybody,anyone,anything,are,around,as,aside,astraddle,astride,at,away,bar,barring,be,because,been,before,behind,being,below,beneath,beside,besides,better,between,beyond,bit,both,but,by,can,certain,circa,close,concerning,consequently,considering,could,couple,dare,deal,despite,down,due,during,each,eight,eighth,either,enough,every,everybody,everyone,everything,except,excepting,excluding,failing,few,fewer,fifth,first,five,following,for,four,fourth,from,front,given,good,great,had,half,have,he,heaps,hence,her,hers,herself,him,himself,his,however,i,if,in,including,inside,instead,into,is,it,its,itself,keeping,lack,less,like,little,loads,lots,majority,many,masses,may,me,might,mine,minority,minus,more,most,much,must,my,myself,near,need,neither,nevertheless,next,nine,ninth,no,nobody,none,nor,nothing,notwithstanding,number,numbers,of,off,on,once,one,onto,opposite,or,other,ought,our,ours,ourselves,out,outside,over,part,past,pending,per,pertaining,place,plenty,plethora,plus,quantities,quantity,quarter,regarding,remainder,respecting,rest,round,save,saving,second,seven,seventh,several,shall,she,should,similar,since,six,sixth,so,some,somebody,someone,something,spite,such,ten,tenth,than,thanks,that,the,their,theirs,them,themselves,then,thence,therefore,these,they,third,this,those,though,three,through,throughout,thru,thus,till,time,to,tons,top,toward,towards,two,under,underneath,unless,unlike,until,unto,up,upon,us,used,various,versus,via,view,wanting,was,we,were,what,whatever,when,whenever,where,whereas,wherever,whether,which,whichever,while,whilst,who,whoever,whole,whom,whomever,whose,will,with,within,without,would,yet,you,your,yours,yourself,yourselves'.split(',').collect {|v| [v, 0]}]

  # Print CSV header
  if want_header
    puts "words,chars," +
      word_shapes.keys.join(',') + ',' +
      word_lens.keys.join(',') + ',' +
      alpha_chars.keys.join(',') + ',' +
      num_chars.keys.join(',') + ',' +
      punc_chars.keys.collect{|v| q = v.gsub(/\"/, "\"\""); "\"#{q}\""}.join(',') + ',' +
      spec_chars.keys.collect{|v| "\"#{v}\""}.join(',') + ',non_ascii_chars,' +
      func_words.keys.join(',')
  end

  ARGF.each do |line|
    # Handle CSV
    csv_fields = (CSV.parse_line(line, :row_sep => "\n"))[0];
    text = csv_fields

    # Reset counts
    [word_shapes, word_lens, num_chars, alpha_chars, punc_chars, spec_chars, func_words].each do |h|
      h.each_key{|k| h[k] = 0}
    end

    char_count = text.length
    non_ascii_chars = 0
    # Collect character-level features.
    text.each_char do |c|
      lower = c.downcase
      alpha_chars[lower] += 1 if alpha_chars.member?(lower)
      num_chars[c] += 1 if num_chars.member?(c)
      punc_chars[c] += 1 if punc_chars.member?(c)
      spec_chars[c] += 1 if spec_chars.member?(c)
      non_ascii_chars += 1 if (c.ord > 127)
    end

    # Collect word-level features.
    words = text.split(/[\b\s\\\"]/)
    # Remove trailing punctuation
    words.collect!{|word| word.gsub(/\W+$/, '')}
    words.reject!{|s| s.empty?}

    word_count = words.length
    words.each do |word|

      # Word shape
      if (word =~ /^[a-z]+$/)
        word_shapes['lower'] += 1
      elsif (word =~ /^[A-Z]+$/)
        word_shapes['upper'] += 1
      elsif (word =~ /^[A-Z][a-z]*$/)
        word_shapes['first_upper'] += 1
      elsif (word =~ /^[A-Z][a-zA-Z]$/)
        word_shapes['camel_case'] += 1
      else
        word_shapes['other_case'] += 1
      end

      # Word length
      wl_key = "words_len_#{word.length}"
      word_lens[wl_key] += 1 if word_lens.member?(wl_key)

      # Function/stop words
      word.downcase!
      func_words[word] += 1 if func_words.member?(word)
    end

    puts "#{word_count},#{char_count}," +
      word_shapes.values.join(',') + ',' +
      word_lens.values.join(',') + ',' +
      alpha_chars.values.join(',') + ',' +
      num_chars.values.join(',') + ',' +
      punc_chars.values.join(',') + ',' +
      spec_chars.values.join(',') + ",#{non_ascii_chars}," +
      func_words.values.join(',')
  end

  exit 0
end

main
