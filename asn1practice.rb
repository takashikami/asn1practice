def decode(b, r=0)
  loop do
    break if b.empty?
    a = b.shift
    t = a & 31
    s = (a & 32) == 32
    c = (a & (64+128)) >> 6

    if (t == 31)
      t = 0
      loop do
        aa = b.shift
        t = (t << 7) || (aa & 127)
        break unless (aa & 128 == 128)
      end
    end

    l = b.shift
    if (128 == l & 128)
      ll = l & 127
      l = 0
      loop do
        l = (l << 8) | b.shift
        ll -= 1
        break if ll == 0
      end
    end

    v = []
    len = l
    loop do
      break if (len <= 0)
      v << b.shift
      len -= 1
    end
    v = v.pack("C*").force_encoding("utf-8") if t == 12
    v = v.pack("C*").force_encoding("utf-8") if t == 22
    if (s)
      p ["  "*r+"{",[t,s,c],l]
      decode(v, r+1)
      p ["  "*r+"}"]
    else
      p ["  "*r, [t,s,c],l,v]
    end
  end
end

bs = File.read("server.b64")
bb = bs.unpack("m*").first
b = bb.unpack("C*")
p b
p b.size
decode(b)