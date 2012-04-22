module DocSim

	# This class provides the document comparison routines.
	#
	class DocumentAnalyzer

		# This function returns a hash from the document name to the
		# term_set map for each file in a directory
		def self.get_terms_for_documents(dir)
			doc_hash = {}
			# iterate through each document
			Dir.foreach(dir) do |file|
				if (file != ".." && file != ".")
					doc = Document.load_file("#{dir}/#{file}")
					terms = doc.term_map
					doc_hash[file] = terms
					#puts "File #{file} processed. (#{terms.size} terms)"
				end
			end
			doc_hash
		end

		# This function builds the complete term set (a hash of all the terms
		# found in all documents, mapping each term to the document frequency)
		def self.build_full_term_set(doc_hash)
			term_set = TermSet.new
			# iterate through each document
			doc_hash.each do |filename, terms|
				term_set.add_document_terms(terms)
			end
			term_set
		end

		# compares 2 documents by building vector models for both and
		# taking the cosine of the angle between them
		def self.compare_documents(full_term_set, doc_map1, doc_map2, doc_count)
			# build vectors
			#vector1 = self.build_vector_model(full_term_set, doc_map1)
			#vector2 = self.build_vector_model(full_term_set, doc_map2)
      vectors = self.build_vector_models(full_term_set, doc_map1, doc_map2, doc_count)

			cos = VectorMath.cosine(vectors[0], vectors[1])
		end

		# builds a weighted vector model for a document using the term frequency
		# and document frequency
		def self.build_vector_model(full_term_set, doc_map)
			vector = Hash.new(0)
			term_count = doc_map.values.sum.to_f
			full_term_set.each do |term, df|
				tf = doc_map[term] / term_count
				#puts "tf for #{term} = #{tf}"
				idf = Math.log(1.0 / df.to_f)
				vector[term] = tf * idf
			end
			vector
		end

    # builds vector models for both documents at once
    def self.build_vector_models(full_term_set, doc_map1, doc_map2, doc_count)
      vectors = [Hash.new(0), Hash.new(0)]
      term_count1 = doc_map1.values.sum.to_f
      term_count2 = doc_map2.values.sum.to_f
      full_term_set.each do |term, df|
        tf1 = doc_map1[term] / term_count1
        tf2 = doc_map2[term] / term_count2
        idf = Math.log(doc_count / df.to_f)
        vectors[0][term] = tf1 * idf
        vectors[1][term] = tf2 * idf
      end
      vectors
    end

		# compares all documents within the document hash 
		def self.compare_all_documents(full_term_set, doc_hash)
			# compare all documents using some dynamic programming
			docs = doc_hash.keys
			memory = {}
			results = {}
			docs.each_index do |index1|
				doc1_file = docs[index1]
				puts "Comparing #{doc1_file} to other docs..."
				results[doc1_file] = {}
				memory[index1] = {}	# for saving results
				
				docs.each_index do |index2|
					doc2_file = docs[index2]
					if (index1 < index2)
						memory[index1][index2] = self.compare_documents(full_term_set, doc_hash[doc1_file], doc_hash[doc2_file])
						results[doc1_file][doc2_file] = memory[index1][index2]
					elsif (index1 > index2)
						results[doc1_file][doc2_file] = memory[index2][index1]
					else
						results[doc1_file][doc2_file] = 1
					end
				end

				# sort results for each file
				#results[doc1_file] = results[doc1_file].sort do |a,b|
				#	b[1] <=> a[1]
				#end
			end

			results
		end

		# returns array of terms that have a term frequency 2 standard deviations
		# about the expected frequency (feature set 1 requirement)
		def self.get_high_frequency_terms(doc_map)
			counts = doc_map.values
			mean_freq = counts.mean
			std_freq = counts.stdev
			words = doc_map.keys.reject! do |key|
				doc_map[key] < mean_freq + 2*std_freq
			end
		end

	end

	# Class to hold terms that appear in all documents. Stores the frequency
	# that each term occurs for the entire document set.
	class TermSet

		def initialize
			@term_hash = Hash.new(0)
		end

		def get_hash
			@term_hash
		end

		# build term set for document hash 
		def add_document_terms(terms)
			terms.each_key do |term|
				@term_hash[term] = @term_hash[term] + 1
			end
		end

		# get the frequency that a term occurs in all documents (feature set 1 
		# requirement)
		def get_document_frequency(term)
			@term_hash[term]
		end

		def each
			@term_hash.each do |key, value|
				yield key, value
			end
		end

		def each_term
			@term_hash.each_key do |key|
				yield key
			end
		end
	end

	class Array
		# find sum of array of numbers
		def sum
			inject(0) do |sum, elem|
				sum + elem
			end
		end

		# find sum of squares of array of numbers
		def sum_of_squares
			inject(0) do |sum, elem|
				sum + (elem ** 2)
			end
		end

		# find average of array of numbers
		def mean
			(self.size > 0) ? (self.sum.to_f / self.size) : 0
		end

		# find standard deviation of array of numbers
		def stdev
			val = ((self.sum_of_squares / self.size.to_f) - (self.mean ** 2)) ** 0.5
		end
	end

end

