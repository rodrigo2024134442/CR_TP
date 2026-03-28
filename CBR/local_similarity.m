function sim = local_similarity(v1, v2)

if isnumeric(v1)
    dist = abs(v1 - v2);
    sim = 1 / (1 + dist);
else
    sim = double(v1 == v2);
end

end