require "rails_helper"

RSpec.configure do |c|
	c.include ModelHelper
end

describe Api::JobsController do
	before :each do
		config_init
		@api_key = Rails.application.config.api_key
	end

	describe "GET job_metadata" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :job_metadata, api_key: @api_key, job_id: "wrong"
				expect(json['status']['code'] == -1).to be true
			end 
		end
		context "with valid attributes" do 
			it "Returns metadata" do
				get :job_metadata, api_key: @api_key, job_id: 1
				expect(json['status']['code'] == 0).to be true
			end
		end
	end
	describe "GET update_metadata" do 
		context "with invalid attributes" do 
			it "returns a json message" do 
				get :update_metadata, api_key: @api_key, job_id: "wrong", key: "0001", metadata: {}
				expect(json['status']['code'] == -1).to be true
			end 
		end
		context "with valid attributes" do 
			it "Returns success and updates metadata" do
				get :update_metadata, api_key: @api_key, job_id: 1, key: "0001", metadata: {type: "test"}
				expect(json['status']['code'] == 0).to be true
			end
		end
	end
	describe "GET process_request" do 
		context "with invalid process_id" do 
			it "returns a json message" do 
				get :process_request, api_key: @api_key, process_code: "test"
				expect(json['status']['code'] == -1).to be true
				expect(json['status']['error']['code'] == 103).to be true
			end 
		end
		context "with valid attributes and a waiting job" do 
			it "Returns success and job id" do
				get :process_request, api_key: @api_key, process_code: "scan_job"
				expect(json['status']['code'] == 0).to be true
				expect(json['data']['job_id'].nil?).to be false
				job = Job.find(json['data']['job_id'])
				#expect(job.current_processing_entry.state == "STARTED").to be true
			end
		end
		context "with valid attributes, but too many processes going on" do 
			it "Returns fail and error message" do
				get :process_request, api_key: @api_key, process_code: "rename_files"
				expect(json['status']['code'] == -1).to be true
				expect(json['status']['error']['code'] == 104).to be true
			end
		end
		context "with valid attributes, but no job waiting" do 
			it "Returns fail and error message" do
				get :process_request, api_key: @api_key, process_code: "copy_files"
				expect(json['status']['code'] == -1).to be true
				expect(json['status']['error']['code'] == 104).to be true
			end
		end
	end
	describe "GET process_initiate" do
		context "job exists and is PENDING" do
			it "should return a success json message" do
				get :process_initiate, api_key: @api_key, job_id: 1, process_code: "scan_job"
				expect(json['status']['code']).to eq(0)
			end
		end
		context "job exist and is STARTED" do
			it "should return an error message" do
				get :process_initiate, api_key: @api_key, job_id: 3, process_code: "copy_files"
				expect(json['status']['code']).to eq(-1)
			end
		end
	end
	describe "GET process_done" do
		context "job exists and is STARTED" do
			it "should return a success json message" do
				get :process_done, api_key: @api_key, job_id: 2, process_code: "rename_files"
				expect(json['status']['code']).to eq(0)
			end
		end
		context "job exist and is PENDING" do
			it "should return a success json message" do
				get :process_done, api_key: @api_key, job_id: 1, process_code: "scan_job"
				expect(json['status']['code']).to eq(0)
			end
		end
	end
	describe "GET process_progress" do
		context "job exists and is STARTED" do
			it "should return a success json message" do
				get :process_progress, api_key: @api_key, job_id: 2, process_code: "rename_files", progress_info: {total: 10, done: 2, percent_done: 20}
				expect(json['status']['code']).to eq(0)
			end
		end
	end
end