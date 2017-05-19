defmodule Remodel.Formatter.ListFormatter do

  def format(resource, serializer, %{headers: true}=options) when is_list(resource),
    do: [format_header(resource, serializer) | format_resources(resource, serializer, %{headers: true}=options)]

  def format(resource, serializer, %{headers: true}=options) when is_map(resource),
    do: [format_header(resource, serializer) | [format_resources(resource, serializer, options)]]

  def format(resource, serializer, options),
    do: format_resources(resource, serializer, options)

  defp format_resources(resources, serializer, options) when is_list(resources),
    do: Enum.map(resources, fn(resource) -> format_resources(resource, serializer, options) end)

  defp format_resources(resource, serializer, options) do
    Enum.map serializer.__attributes, fn(attr) ->
      if !attr.if || apply(serializer, attr.if, [resource, options[:scope]]) do
        apply(serializer, attr.attribute, [resource, options[:scope]])
      else
        nil
      end
    end
  end

  defp format_header(resource, serializer) do
    Enum.map(serializer.__attributes, fn(attr) ->
      alias =
        if attr.as && is_atom(attr.as) && Keyword.has_key?(serializer.__info__(:functions), attr.as) do
          apply(serializer, attr.as, [resource])
        end

      alias || to_string(attr.as || attr.attribute)
    end)
  end
end
