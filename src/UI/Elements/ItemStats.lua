return function(stats,frame)
	local iframe = frame.Frame
	for _,ch in pairs(iframe:GetChildren()) do
		if not ch:IsA("UIListLayout") then
			ch:Destroy()
		end
	end
	if not stats then return end

	if stats["neutral"] then
		local ref = frame.neutral
		for _,stat in pairs(stats["neutral"]) do
			local st = ref:Clone()
			st.Text = stat
			st.Visible = true
			st.Parent = iframe
		end
	end
	if stats["positive"] then
		local ref = frame.positive
		for _,stat in pairs(stats["positive"]) do
			local st = ref:Clone()
			st.Text = stat
			st.Visible = true
			st.Parent = iframe
		end
	end
	if stats["negative"] then
		local ref = frame.negative
		for _,stat in pairs(stats["negative"]) do
			local st = ref:Clone()
			st.Text = stat
			st.Visible = true
			st.Parent = iframe
		end
	end

end
