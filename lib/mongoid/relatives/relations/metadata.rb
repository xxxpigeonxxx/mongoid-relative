require "mongoid/relations"

module Mongoid
  module Relatives
    module Relations
      class Metadata < Mongoid::Relations::Metadata

        def class_path
          self[:class_path]
        end

        def related_klass
          path = class_path.split(".")
          last = klass
          path.each do |relation_name|
            last = last.relations[relation_name].klass
          end
          last
        end

        def determine_inverse_relation
          default = foreign_key_match || klass.relations[inverse_klass.name.underscore]
          return default.name if default
          names = inverse_relation_candidate_names
          if names.size > 1
            raise Errors::AmbiguousRelationship.new(klass, inverse_klass, name, names)
          end
          names.first
        end

        def inverse_relation_candidates
          if class_path
            path = class_path.split(".")
            pathed_class = klass
            path.each do |relation|
              pathed_class = pathed_class.relations[relation].klass
            end
            pathed_class.relations.values.select do |meta|
              next if meta.name == name
              (meta.class_name == inverse_class_name) && !meta.forced_nil_inverse?
            end
          else
            relations_metadata.select do |meta|
              next if meta.name == name
              if meta.respond_to? "class_path"
                pathed_class = meta.klass
                path = meta.class_path.split(".")
                path.each do |relation|
                  pathed_class = pathed_class.relations[relation].klass
                end
                (pathed_class == inverse_klass) && !meta.forced_nil_inverse?
              else
                (meta.class_name == inverse_class_name) && !meta.forced_nil_inverse?
              end
            end
          end
        end

        def inspect
%Q{#<Mongoid::Relatives::Relations::Metadata
  autobuild:    #{autobuilding?}
  class_name:   #{class_name}
  class_path:   #{class_path}
  cyclic:       #{cyclic.inspect}
  counter_cache:#{counter_cached?}
  dependent:    #{dependent.inspect}
  inverse_of:   #{inverse_of.inspect}
  key:          #{key}
  macro:        #{macro}
  name:         #{name}
  order:        #{order.inspect}
  polymorphic:  #{polymorphic?}
  relation:     #{relation}
  setter:       #{setter}>
}
        end
      end
    end
  end
end
