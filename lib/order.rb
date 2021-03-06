require 'csv'
require_relative 'customer.rb'

class Order

	attr_reader :id
	attr_accessor :products, :customer, :fulfillment_status

	def initialize(id, products, customer, fulfillment_status = :pending)
		if [:pending, :paid, :processing, :shipped, :complete].include?(fulfillment_status) != true
			raise ArgumentError.new("Invalid fulfillment status passed.") 
		end
		@id = id
		@products = products
		@customer = customer
		@fulfillment_status = fulfillment_status
	end

	# Finds all orders.
	def self.all
		all_orders = [] # Variable holding all orders.

		CSV.read('data/orders.csv').each do |line|
			order_products = {} # Variable holding all products in an order.
			
			line[1].split(';').each do |product|
				order_products[product.split(':')[0]] = product.split(':')[1].to_f
			end

			new_order = self.new(line[0].to_i, order_products, Customer.find(line[2].to_i), line[3].to_sym)
			all_orders << new_order
		end

		return all_orders
	end

	# Locates a specific order.
	def self.find(id)
		all_orders = self.all # Variable holding all orders available.

		all_orders.each do |order|
			if id == order.id
				return order
			end
		end

		return nil
	end

	# Returns all orders belonging to a customer ID.
	def self.find_by_customer(customer_id)
		all_orders = self.all # Variable holding all orders available.
		matched_orders = [] # Variable holding all orders matching customer ID.

		all_orders.each do |order|
			if order.customer.id == customer_id
				matched_orders << order
			end
		end

		return matched_orders
	end

	# Totals the prices of the product list.
	def total
		total = 0.0 # Tracks total price.
		if @products.length == 0
			return total
		else
			@products.values.each do |price|
				total += price
			end
			return (total * 1.075).round(2)
		end
	end

	# Adds a product to the list.
	def add_product(product, price)
		if @products.keys.include?(product)
			raise ArgumentError.new("Product is already included.")
		else
			@products[product] = price
		end
	end

	# Removes a product from the list.
	def remove_product(product)
		if @products.keys.include?(product) == false
			raise ArgumentError.new("Product was not found in list.")
		else
			@products.delete(product)
		end
	end

end