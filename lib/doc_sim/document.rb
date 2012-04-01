require 'rubygems'
require 'open-uri'
require 'stemmer'

# This is an abstract class with encapsulates a Document
#
module DocSim
	class Document
    STOP_WORDS = %w{ the thi these there is a on this and or any from if be do at
  with without not as that nbsp when also wherein therein which each would such further have more will within herein system includ within compris contain other devic provid particular particularli applic some exampl servic method about what thing kind exemplari both than into must certain thereof becaus through typic forth thereon likewis type although moreov those thereto been henc manner necessarili refer variou while howev gener regard rather mere suitabl accordingli disclos anymor said claim overal embodi appropri suitabl where then accord content item whether consid might given s to t us could well d made data object invent ar for fig can ha let ani it but etc who via yet did get how few per try met all thu doe mai wa }
    SHORT_WORDS = %{ top pay ad ads }

		# new from string
		def initialize(doc)
			@doc = doc.downcase
		end

		# create document from website url
		def self.load_url(url)
			begin
				Document.new open(url).read
			rescue Exception=>e
				puts "ERROR: Couldn't load url #{url}"
				return Document.new("")
			end
		end

		# create document from file
		def self.load_file(filename)
			Document.new File.open(filename).read
		end

		# write document to file using specified method (i.e. append, overwrite)
		def write_to_file(filename, method)
			File.open(filename, method) do |file|
				file.write(@doc)
			end
		end

		# iterates over each term in document, returning root form
		def each_term
			self.to_terms.each do |term|
				yield term.stem
			end
		end

		# returns array of all terms found in document
		def to_terms
			raise "Document invalid." unless @doc
			terms = @doc.gsub(/(\d|\W)+/u, ' ').strip.split(' ')
			terms.reject! do |term|
				#@@stop_words.include?(term) || term.length < 4 || term.length > 20
        ((term.length < 3 && !SHORT_WORDS.include?(term)) || term.length > 20)
			end
      terms.collect! {|term| term.stem}
      terms = terms.select {|term| term.length > 1}
			terms - STOP_WORDS
		end

		# removes all html, scripts, and style tags from document
		def sanitize!
			@doc.downcase!
			@doc.gsub!(/<style.*?\/style>/m, '')
			@doc.gsub!(/<script.*?\/script>/m, '')
			@doc.gsub!(/<.*?>/m, ' ')
			@doc.gsub!(/\s+/, ' ')
		end

		def to_s
			@doc
		end

		# returns hash of document terms, mapping each term to its frequency found
		# within the document
		def term_map
			term_set = Hash.new(0)
			self.to_terms.each do |term|
				term_set[term] = term_set[term] + 1
			end
			term_set
		end

    def top_terms(count)
      term_map.to_a.sort! {|x, y| y.second <=> x.second }[0..count]
    end

	end
end

class String
	include Stemmable
end

