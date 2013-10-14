require 'spec_helper'
require 'orm_adapter/example_app_shared'
require 'orm_adapter/adapters/ripple'

if !defined?(Ripple) || !(Riak::Client.new['orm_adapter_spec'] rescue nil)
  puts "** require 'ripple' and start riak to run the specs in #{__FILE__}"
else

  @connection = Riak::Client.new
  @database = @connection['orm_adapter_spec']


  module RippleOrmSpec
    class User
      include Ripple::Document
      property :name, :type => String
      property :rating, :type => String
      many :notes, :foreign_key => :owner_id, :class_name => 'RippleOrmSpec::Note'
      alias :id :key
    end

    class Note
      include Ripple::Document
      property :body, :default => "made by orm", :type => String
      one :owner, :class_name => 'RippleOrmSpec::User'
    end

    # here be the specs!
    describe Ripple::Document::OrmAdapter do

      before do
        @database.keys.each do |coll|
          coll.remove
        end unless @database.nil?
      end

      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end