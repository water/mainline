OAuth::Consumer.class_eval {
  remove_const(:CA_FILE) if const_defined?(:CA_FILE)
}

OAuth::Consumer::CA_FILE = nil
