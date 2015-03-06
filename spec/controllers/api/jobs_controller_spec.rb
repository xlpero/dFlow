require "rails_helper"

describe Api::JobsController do
  before :each do
    WebMock.allow_net_connect!
    @api_key = APP_CONFIG["api_key"]
  end
  after :each do
    WebMock.allow_net_connect!
  end

  describe "GET index" do
    context "with existing jobs" do
      it "should return all jobs" do
        create_list(:job,10)
        get :index, api_key: @api_key
        expect(json['jobs'].size).to be > 0
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET show" do
    context "with existing job" do
      it "should return full job object data" do

        job = create(:job)
        get :show, api_key: @api_key, id: job.id
        expect(json['job'].size).to be > 0
        expect(response.status).to eq 200
        expect(json['job']['breadcrumb']).to be_kind_of(Array)
      end
    end

    context "with non-existing job" do
      it "should return 404" do
        get :show, api_key: @api_key, id: 9999999
        expect(response.status).to eq 404
      end
    end
  end

  describe "Create job" do
    context "with valid job parameters" do
      it "should create job without errors" do
        treenode = create(:child_treenode)
        post :create, api_key: @api_key, job: {source: 'libris', treenode_id: treenode.id, name: 'the jobname', comment: 'comment', title: 'The best book ever', catalog_id: '1234', copyright: true, status: 'waiting_for_digitizing'}
        expect(json['error']).to be nil
      end
      it "should return the created object" do
        treenode = create(:treenode)
        post :create, api_key: @api_key, job: {source: 'libris', treenode_id: treenode.id, name: 'the jobname', comment: 'comment', title: 'The best book ever', catalog_id: '1234', copyright: 'false', status: 'waiting_for_digitizing'}
        expect(json['job']).not_to be nil
        expect(json['job']['id']).not_to be nil
        expect(json['job']['name']).to eq('the jobname')
        expect(json['job']['copyright']).to eq(false)
      end
    end
    context "with invalid job parameters" do
      it "should return an error message" do
        treenode = create(:treenode)
        post :create, api_key: @api_key, job: {source: 'libris', cataloz_id: '1234', title: 'Bamse och hens vänner', treenode_id: treenode.id, name: 'Bamse-jobbet', comment: 'comment'}
        expect(json['error']).to_not be nil
      end
    end

    context "with a provided ID" do
      it "should create job and return JSON representation of that job" do
        job_id = 90000
        job_name = "The Jobb with the custom ID"
        treenode = create(:treenode)
        post :create, api_key: @api_key, force_id: "#{job_id}", job: {source: 'libris', treenode_id: treenode.id, name: job_name, comment: 'comment', title: 'The best book ever', catalog_id: '1234', copyright: 'false', status: 'waiting_for_digitizing'}
        expect(json['error']).to be nil
        expect(json['job']).not_to be nil
        expect(json['job']['id']).to eq(job_id)
        expect(json['job']['name']).to eq(job_name)
      end
    end
  end

  describe "GET index" do
    context "pagination" do
      it "should return metadata about pagination" do
        Job.per_page = 4
        number_of_jobs = 40
        create_list(:job, number_of_jobs)
        get :index
        expect(json['jobs']).to_not be_empty
        expect(json['jobs'].count).to eq(4)
        #expect(json['meta']['query']['query']).to eq("Test")
        expect(json['meta']['query']['total']).to eq(number_of_jobs)
        expect(json['meta']['pagination']['pages']).to eq(10)
        expect(json['meta']['pagination']['page']).to eq(1)
        expect(json['meta']['pagination']['next']).to eq(2)
        expect(json['meta']['pagination']['previous']).to eq(nil)
        expect(json['meta']['pagination']['per_page']).to eq(4)
      end
      it "should return paginated second page when given page number" do
        Job.per_page = 4
        number_of_jobs = 40
        create_list(:job, number_of_jobs)
        get :index, page: 2
        expect(json['jobs']).to_not be_empty
        expect(json['jobs'].count).to eq(4)
        #expect(json['meta']['query']['query']).to eq("Test")
        expect(json['meta']['query']['total']).to eq(40)
        expect(json['meta']['pagination']['pages']).to eq(10)
        expect(json['meta']['pagination']['page']).to eq(2)
        expect(json['meta']['pagination']['next']).to eq(3)
        expect(json['meta']['pagination']['previous']).to eq(1)
      end
      it "should return first page when given out of bounds page number" do
        Job.per_page = 4
        number_of_jobs = 40
        create_list(:job, number_of_jobs)
        get :index, page: 20000000000
        expect(json['jobs']).to_not be_empty
        expect(json['jobs'].count).to eq(4)
        #expect(json['meta']['query']['query']).to eq("Test")
        expect(json['meta']['query']['total']).to eq(40)
        expect(json['meta']['pagination']['pages']).to eq(10)
        expect(json['meta']['pagination']['page']).to eq(1)
        expect(json['meta']['pagination']['next']).to eq(2)
        expect(json['meta']['pagination']['previous']).to eq(nil)
      end
    end
  end

end
