defmodule Leadfoot.TranslationTest do
  use ExUnit.Case

  alias Leadfoot.Translation

  @moduletag :capture_log

  doctest Translation

  test "module exists" do
    assert is_list(Translation.module_info())
  end

  test "format time to hh mm ss" do
    assert Leadfoot.Translation.to_hh_mm_ss(12000.12) == "03:20:00"
    assert Leadfoot.Translation.to_hh_mm_ss(1200.12) == "20:00"
    assert Leadfoot.Translation.to_hh_mm_ss(1212.12) == "20:12"
  end

  test "format time to mm ss ms" do
    assert Leadfoot.Translation.to_mm_ss_ms(1212.12) == "20:12.120"
    assert Leadfoot.Translation.to_mm_ss_ms(123.123) == "02:03.123"
    assert Leadfoot.Translation.to_mm_ss_ms(1234.1234) == "20:34.123"
  end
end
