require 'spec_helper'

describe 'cdap::master' do
  context 'using default cdap version' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.9) do |node|
        node.automatic['domain'] = 'example.com'
        node.default['hadoop']['hdfs_site']['dfs.datanode.max.transfer.threads'] = '4096'
        node.default['hadoop']['mapred_site']['mapreduce.framework.name'] = 'yarn'
        stub_command(/update-alternatives --display /).and_return(false)
        stub_command(/test -L /).and_return(false)
      end.converge(described_recipe)
    end
    pkg = 'cdap-master'

    %w(
      cdap-hbase-compat-1.1
      cdap-hbase-compat-1.2-cdh5.7.0
    ).each do |compat|
      it "installs #{compat} package" do
        expect(chef_run).to install_package(compat)
      end
    end

    %W(
      /etc/init.d/#{pkg}
    ).each do |file|
      it "creates #{file} from template" do
        expect(chef_run).to create_template(file)
      end
    end

    it "installs #{pkg} package" do
      expect(chef_run).to install_package(pkg)
    end

    it "creates #{pkg} service, but does not run it" do
      expect(chef_run).not_to start_service(pkg)
    end

    it 'creates cdap-upgrade-tool resource, but does not execute it' do
      expect(chef_run).not_to run_execute('cdap-upgrade-tool')
    end
  end

end
