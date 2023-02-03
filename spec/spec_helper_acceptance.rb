require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_ca_certs unless %r{pe}i.match?(ENV['PUPPET_INSTALL_TYPE'])
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Readable test descriptions
  c.formatter = :documentation
  hosts.each do |host|
    if host[:platform].include?('el-7-x86_64') && host[:hypervisor].include?('docker')
      on(host, "sed -i '/nodocs/d' /etc/yum.conf")
    end
  end
  if fact('osfamily') == 'Debian'
    c.filter_run_excluding skip_run: true
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes', :skip_run do
    apply_manifest(pp, catch_changes: true)
  end
end
