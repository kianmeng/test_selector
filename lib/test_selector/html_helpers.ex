defmodule TestSelector.HTMLHelpers do
  @moduledoc """
  Documentation for TestSelector. In the examples we're using the UserView as
  a plain example, this is obviously tradable for any view
  """

  defmacro __using__(_options) do
    quote do
      import TestSelector.HTMLHelpers

      @doc """
      Generates a unique code for an html element

      ## Examples

          iex(1)> UserView.test_selector()
          "user-45e6f"

      """
      def test_selector do
        __MODULE__
        |> Module.split()
        |> List.last()
        |> (&List.insert_at([], 0, &1)).()
        |> Enum.join("-")
        |> String.trim_trailing("View")
        |> String.trim_trailing("Cell")
        |> String.downcase()
        |> Kernel.<>("-#{test_hash()}")
      end

      @doc """
      ## Example

          iex()> UserCell.test_selector("avatar")
          "user-45e6f-avatar"
      """
      def test_selector(name) do
        test_selector()
        |> Kernel.<>("-#{name}")
      end

      @doc """
      The test function will return both the HTML attribute and it's value
      ## Examples

          iex()> UserCell.test()
          "test-selector=\"user-45e6f\""

      In the user show template:

          <a href="#" <%= test() %>>

          # results in
          <a href="#" test-selector="user-45e6f">
      """
      def test do
        test_selector()
        |> test_attributes()
      end
      @doc """
      The test function will return both the HTML attribute and it's value
      ## Examples

      With just a name

          iex()> UserCell.test("avatar")
          "test-selector=\"user-45e6f-avatar\""

      With both a name and value

          iex()> UserCell.test("id", 13)
          "test-selector=\"user-45e6f-id\" test-value=\"13\""

      In the user show template:

          <a href="#" <%= test("foo") %>>
          <a href="#" <%= test("foo", "bar") %>>

          <a href="#" test-selector="<%= test_selector("foo") %>">
          <a href="#" test-selector="<%= test_selector("foo") %> test-value="bar">
      """
      def test(name, value \\ nil) do
        name
        |> test_selector()
        |> test_attributes(value)
      end

      def test_hash do
        :md5
        |> :crypto.hash("#{__MODULE__}")
        |> Base.encode16(case: :lower)
        |> String.slice(0, 5)
      end

      defoverridable [
        test_selector: 0,
        test_selector: 1
      ]
    end
  end


  def test_attributes(selector) do
    output_attributes(raw(~s(test-selector="#{selector}")))
  end
  def test_attributes(selector, nil), do: test_attributes(selector)
  def test_attributes(selector, value) do
    output_attributes(raw(~s(test-selector="#{selector}" test-value="#{value}")))
  end
  defp output_attributes(attributes) do
    case Mix.env do
      :prod -> ""
      _ -> attributes
    end
  end

  def raw({:safe, value}), do: {:safe, value}
  def raw(nil), do: {:safe, ""}
  def raw(value) when is_binary(value) or is_list(value), do: {:safe, value}
end
