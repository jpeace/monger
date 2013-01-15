# MONGER DSL
# 'map' maps an entity
# 'interface' maps an interface
#
# entity.is_a Namespace::Class [optional]
# entity.is_a_type_of Namespace::Interface [required if implements an interface]
#
# entity.is :behavior
#
# entity.has_string(s) :prop1, :prop2
# entity.has_integer(s) :prop1, :prop2
# entity.has_number(s) :prop1, :prop2
# entity.has_date(s) :prop1, :prop2
# entity.has_time(s) :prop1, :prop2
# entity.has_email(s)
# entity.has_phone(s)
#
# entity.has_a :ref_name, { :is_a | :is_an => :type, :is_a_type_of => :type } [optional], :related_by => :value (inline) | :reference (id)
# entity.has_many :refs_name, { :are => :type, :are_types_of => :type } [optional], :related_by => :value (inline) | :reference (id)
#
# (parent-child relationships)
# entity.has_a :ref_name, :related_to_parent_by => :parent_ref_prop (1-many)
# entity.has_many :refs_name, :related_to_parent_by => :parent_refs_prop (many-many)
#

# general

map :contact do |contact|
  contact.is_a Titan::Domain::General::Contact
  contact.has_strings :first_name, :last_name
  contact.has_email :email
  contact.has_phone :phone
end

map :address do |address|
  address.is_an Titan::Domain::General::Address
  address.has_strings :address1, :address2, :city, :state, :zip, :country
end


# commerce

map :store do |store|
  store.is_a Titan::Store::Domain::Store
  store.has_many :products, :are => :product, :related_by => :reference
  store.has_many :orders, :are => :order, :related_by => :reference
end

map :order do |order|
  order.is_a Titan::Store::Domain::Order
  order.is :timestampable
  order.has_string :status
  order.has_a :store, :related_to_parent_by => :orders
  order.has_a :sales_channel, :related_by => :reference
  order.has_a :shipping_option, :related_by => :value
  order.has_a :customer, :related_by => :reference
  order.has_a :shipping_address, :is_an => :address, :related_by => :value
  order.has_a :payment, :is_a => :credit_card, :related_by => :value
  order.has_many :line_items, :are => :line_item, :related_by => :value
  order.has_many :fees, :are_types_of => :fee, :related_by => :value
end

map :line_item do |item|
  item.is_a Titan::Store::Domain::LineItem
  item.has_integer :quantity
  item.has_a :product, :related_by => :value
end

map :product do |product|
  product.is_a Titan::Store::Domain::Product
  product.has_a :store, :related_to_parent_by => :products
  product.has_strings :name, :type, :item
  product.has_number :price
end

map :customer do |customer|
  customer.is_a Titan::Store::Domain::Customer
  customer.has_a :contact, :related_by => :reference
  customer.has_many :orders, :are => :order, :related_to_parent_by => :customer
end

map :credit_card do |card|
  card.is_a Titan::Store::Domain::CreditCard
  card.has_strings :last_four, :authorize_token
  card.has_a :billing_address, :is_an => :address, :related_by => :value
end

interface :sales_channel do |channel|
  channel.is_a Titan::Store::Domain::Interfaces::SalesChannel
end


map :flat_fee do |fee|
  fee.is_a Titan::Store::Domain::FlatFee
  fee.is_a_type_of :fee, :where_discriminator_is => "flat"
end

map :percentage_fee do |fee|
  fee.is_a Titan::Store::Domain::PercentageFee
  fee.is_a_type_of :fee, :where_discriminator_is => "percentage"
end

interface :fee do |fee|
  fee.is_a Titan::Store::Domain::Interfaces::Fee
  fee.discriminator :type, :is_a => :string
  fee.has_string :name
  fee.has_number :amount
end