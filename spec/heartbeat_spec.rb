# frozen_string_literal: true

describe 'heartbeat end-point' do
  it 'should answer pong' do
    get '/api/v1/ping'
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('application/json')
    expect(json_body).to eq(answer: 'pong')
  end
end
