require 'rubygems'
require 'couchrest'

SERVER = CouchRest.new
SERVER.default_database = 'comercio2'
DB = SERVER.default_database

class Cliente < CouchRest::ExtendedDocument
  use_database DB
  
  property :nome
  property :email
  property :telefone
  property :pedidos, :cast_as => ['Pedido'], :default => []
  
  timestamps!
end

class Pedido < CouchRest::ExtendedDocument
  use_database DB
  
  property :numero
  property :valor
  property :data
end

cliente = Cliente.new :nome => "Alan Rafael", :email => "alanbatista@gmail.com", :telefone => "9999-9999"
cliente.pedidos << Pedido.new(:numero => 1, :valor => 10, :data => Time.new)
cliente.pedidos << Pedido.new(:numero => 2, :valor => 105, :data => Time.new)
cliente.pedidos << Pedido.new(:numero => 3, :valor => 140, :data => Time.new)
cliente.save

puts "Identificador do Cliente: #{cliente.id}"

#obtendo o cliente
clienteReloaded = Cliente.get cliente.id

puts "Pedidos do cliente #{clienteReloaded.nome}, são: "
clienteReloaded.pedidos.each do |pedido|
  p pedido
end