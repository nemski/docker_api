defmodule DockerApi.HTTP do

  @moduledoc """
    HTTP handler for all REST calls to the Docker API
  """

  @doc """
  GET 
        iex> DockerApi.HTTP.get("http://httpbin.org/get")
             {:ok, %{body: "foo", headers: _, status_code: 200} }
  """
  def get(url) do
    HTTPoison.get(url) 
  end
 
  @doc """
  GET with query params
  * opts must be a map

        iex> DockerApi.HTTP.get("http://httpbin.org/get", %{foo: 1})
             {:ok, %{body: "foo", headers: _, status_code: 200} }
  """
  def get(url, opts) when is_map(opts) do
    url = url <> "?#{encode_query_params(opts)}"
    HTTPoison.get(url) 
  end
  
  @doc """
  POST with optional payload
  * opts must be a map 
  * payload is sent as JSON

        iex> DockerApi.HTTP.post("http://httpbin.org/get", %{foo: 1})
             {:ok, %{body: "foo", headers: _, status_code: 200} }
  """
  def post(url, opts \\ []) do
    HTTPoison.post(url, Poison.encode!(opts), %{"Content-type" => "application/json"}) 
  end

  def delete(url) do
    HTTPoison.delete(url)
  end

  def delete(url, opts) do
    url = url <> "?#{encode_query_params(opts)}"
    HTTPoison.delete(url)
  end

  def handle_response(resp = {:ok, %{status_code: 200, body: _body}}) do
    parse_response(resp)
  end
 
  def handle_response(resp = {:ok, %{status_code: 201, body: _body}}) do
    parse_response(resp)
  end

  def handle_response(resp = {:ok, %{status_code: 204, body: _body}}) do
    parse_response(resp)
  end
 
  def handle_response(resp = {:ok, %{status_code: 304, body: _body}}) do
    parse_response(resp)
  end
  
  def handle_response(resp = {:ok, %{status_code: 404 , body: _body}}) do 
    parse_response(resp)
  end

  def handle_response(resp = {:ok, %{status_code: 500, body: _body}}) do 
    parse_response(resp)
  end

  def handle_response(resp = {:error, %HTTPoison.Error{id: _, reason: _reason}}) do
    parse_response(resp)
  end

  def parse_response({:error, %HTTPoison.Error{id: _, reason: reason}}) do
    { :error, reason, 500 }
  end
  
  def parse_response({:ok, resp = %HTTPoison.Response{body: "", headers: _headers, status_code: code}}) do
    {:ok, resp.body, code }
  end

  def parse_response({:ok, %HTTPoison.Response{body: body, headers: headers, status_code: code}}) do
    {"Content-Type", type} = List.keyfind(headers, "Content-Type", 0)
    case type do
      "text/plain; charset=utf-8" ->
        {:ok, body, code }
      "application/json" ->
        {:ok, Poison.decode!(body), code }
    end
  end

  def query_params(args)  do
   Enum.map(Map.to_list(args), fn {k,v} -> encode_attribute(k, v) end)
   |> Enum.join("&") 
  end
  
  def encode_query_params(opts) do
   URI.encode_query(opts) 
  end
  
  def encode_attribute(k, v), do: "#{k}=#{encode_value(v)}"

  def encode_value(v), do: URI.encode_www_form("#{v}")
 
end
