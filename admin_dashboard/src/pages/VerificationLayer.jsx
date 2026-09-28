import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Layers, 
  CheckCircle2, 
  Clock, 
  AlertTriangle, 
  HelpCircle, 
  ArrowRight,
  Database,
  ShieldCheck,
  Server
} from 'lucide-react';
import { adminApi } from '../services/adminApi';

export default function VerificationLayer() {
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadLayer() {
      setLoading(true);
      const res = await adminApi.getVerificationLayer();
      setData(res);
      setLoading(false);
    }
    loadLayer();
  }, []);

  if (loading || !data) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[60vh]">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  return (
    <div className="p-8 space-y-8 max-w-7xl mx-auto">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <div className="flex items-center space-x-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">
              Unified Verification & Integration Layer
            </h1>
            <span className="bg-emerald-100 text-emerald-800 text-xs px-2.5 py-0.5 rounded-full font-semibold border border-emerald-300">
              Demo / Mock
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Connected authoritative repositories, state revenue portals, and academic registries
          </p>
        </div>

        <button
          onClick={() => navigate('/admin/reviews')}
          className="inline-flex items-center px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm transition"
        >
          <span>View Manual Review Queue</span>
          <ArrowRight className="w-3.5 h-3.5 ml-1.5" />
        </button>
      </div>

      {/* Grid: Connected Sources & Verification Dimensions */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Table of Sources */}
        <div className="bg-white rounded-xl border border-slate-200/90 shadow-sm overflow-hidden">
          <div className="p-5 border-b border-slate-100 flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Database className="w-4 h-4 text-emerald-600" />
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                Authoritative Government Data Sources
              </h3>
            </div>
            <span className="text-[11px] text-slate-400 font-medium">8 Data Pipelines</span>
          </div>

          <div className="divide-y divide-slate-100">
            {data.sources.map((s, idx) => {
              const isConnected = s.status === 'connected';
              return (
                <div key={idx} className="p-4 hover:bg-slate-50/80 transition flex items-center justify-between text-xs">
                  <div>
                    <div className="flex items-center space-x-2">
                      <span className="font-bold text-slate-900">{s.name}</span>
                      <span className="text-[11px] text-slate-500">• {s.type}</span>
                    </div>
                    <span className="text-[10px] text-slate-400">Response Latency: {s.latency}</span>
                  </div>

                  <div>
                    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold ${
                      isConnected 
                        ? 'bg-emerald-100 text-emerald-800 border border-emerald-300' 
                        : 'bg-amber-50 text-amber-800 border border-amber-200'
                    }`}>
                      {s.badge}
                    </span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Verification Status Across Dimensions */}
        <div className="bg-white rounded-xl border border-slate-200/90 shadow-sm overflow-hidden flex flex-col justify-between">
          <div>
            <div className="p-5 border-b border-slate-100 flex items-center justify-between">
              <div className="flex items-center space-x-2">
                <ShieldCheck className="w-4 h-4 text-emerald-600" />
                <h3 className="text-xs font-bold uppercase tracking-wider text-slate-700">
                  Verification Dimension Matrix
                </h3>
              </div>
              <span className="text-[11px] text-slate-400 font-medium">Active Pipeline Status</span>
            </div>

            <div className="divide-y divide-slate-100">
              {data.verification_entries.map((v, idx) => {
                const isVerified = v.status === 'verified';
                const isActionReq = v.status === 'action_required';
                const isPending = v.status === 'pending';

                return (
                  <div key={idx} className="p-4 hover:bg-slate-50/80 transition flex items-center justify-between text-xs">
                    <div>
                      <span className="font-semibold text-slate-800 block">{v.dimension}</span>
                      <span className="text-[11px] text-slate-400">Source: {v.source}</span>
                    </div>

                    <div>
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold ${
                        isVerified 
                          ? 'bg-emerald-100 text-emerald-800' 
                          : isActionReq
                          ? 'bg-amber-100 text-amber-800'
                          : isPending
                          ? 'bg-blue-100 text-blue-800'
                          : 'bg-slate-100 text-slate-600'
                      }`}>
                        {v.badge}
                      </span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="p-5 bg-slate-50 border-t border-slate-100">
            <div className="flex items-start space-x-3 text-xs text-slate-600">
              <Server className="w-4 h-4 text-emerald-600 shrink-0 mt-0.5" />
              <div>
                <span className="font-bold text-slate-800 block mb-0.5">Discrepancy Routing Rule</span>
                <span>
                  Mismatch cases (such as institutional aliases or expired income certificates) do not trigger automatic rejection. Instead, they are gracefully routed to the Manual Review Queue for officer determination.
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="text-center text-xs text-slate-400 pt-4">
        Simulated Verification Integration Layer • Ministry of Tribal Affairs, Government of India
      </div>
    </div>
  );
}
