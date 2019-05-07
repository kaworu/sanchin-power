# frozen_string_literal: true

describe 'API', :transaction do
  before(:each) do
    creation = create_user build(:user, :with_credentials)
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  context 'when the content-type is not application/json' do
    it 'should return 415 Unsupported Media Type' do
      header 'authorization', "Bearer #{@token}"
      header 'content-type', 'text/plain'
      post '/api/v1/users', '{}'
      expect(last_response.status).to eq(415)
      expect(last_response.body).to be_empty
    end
  end

  context 'when the request body is not JSON formated' do
    it 'should return 400 Bad Request' do
      header 'authorization', "Bearer #{@token}"
      header 'content-type', 'application/json'
      post '/api/v1/users', 'Hello'
      expect(last_response.status).to eq(400)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body[:error]).to eq('failed to parse the request body as JSON')
    end
  end
end
