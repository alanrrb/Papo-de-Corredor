require 'rubygems'
require 'couchrest'

SERVER = CouchRest.new
DB = SERVER.database('comercio')

class Cliente < CouchRest::ExtendedDocument
  use_database DB
  
  property :nome
  property :email
  property :telefone
  
  timestamps!
  
  def pedidos
    Pedido.by_cliente_id :key => id
  end  
end

class Pedido < CouchRest::ExtendedDocument
  use_database DB
  
  property :numero
  property :valor
  property :data
  
  view_by :cliente_id
 
  def cliente= cliente
    self['cliente_id'] = cliente.id
  end
  def cliente
    Cliente.get(self['cliente_id']) if self['cliente_id']
  end
end

cliente = Cliente.new(:nome => "Alan Rafael", :email => "alanrrb@gmail.com", :telefone => "9999-9999")
cliente.save

pedido = Pedido.new
pedido.numero= 1
pedido.valor= 20000
pedido.data = Time.new
pedido.cliente= cliente
pedido.save

pedido = Pedido.new
pedido.numero= 2
pedido.valor= 1000
pedido.data = Time.new
pedido.cliente= cliente
pedido.save

puts "Identificador do Cliente #{cliente.nome}, id: #{cliente.id}"

puts "Pedidos do cliente #{cliente.nome}"
cliente.pedidos.each do |pedido|
  pedido.each do |chave, valor|
    puts "#{chave}: #{valor}"
  end
  puts
end

class Pedido
view_by :valor_total_pedidos, 
              :map =>                                                     
                "function(doc) {
                    if(doc['couchrest-type'] == \"Pedido\")
                       emit(doc['cliente_id'], doc['valor']);
                 }",                                                       
              :reduce =>                                                  
                "function(keys, values, rereduce) {                       
                    return sum(values);                                     
                 }"
end

total =  Pedido.by_valor_total_pedidos :key => cliente.id, :reduce => true
p "Valor total de pedidos para cliente: #{cliente.nome}, Total: #{total['rows'][0]['value']}"