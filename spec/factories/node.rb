Factory.define :node do |f|
    f.sequence(:name) {|n| "Node_#{n}"}
end
