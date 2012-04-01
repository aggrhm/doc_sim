# Module for doing math on vectors. For vectors, I'm just using a Hash (or 
# really anything that can respond to typical Hash methods)
module DocSim
  class VectorMath
    # get dot product of 2 vectors
    def self.dot_product(vector1, vector2)
      sum = 0
      vector1.each_key do |key|
        sum = sum + (vector1[key] * vector2[key])
      end
      sum
    end

    # get magnitude of a vector
    def self.magnitude(vector)
      sum = 0
      vector.each_value do |value|
        sum = sum + value ** 2
      end
      sum ** 0.5
    end

    # get cosine of angle between 2 vectors
    def self.cosine(vector1, vector2)
      val = VectorMath.dot_product(vector1, vector2) / ( VectorMath.magnitude(vector1) * VectorMath.magnitude(vector2) )
    end
  end
end

