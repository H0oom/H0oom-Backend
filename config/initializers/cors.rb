Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # 개발 환경에서는 모든 origin 허용, 프로덕션에서는 특정 도메인만 허용하세요

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false
  end
end
